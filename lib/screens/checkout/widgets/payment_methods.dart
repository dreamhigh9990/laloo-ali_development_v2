import 'package:flutter/material.dart';
import 'package:fstore/env.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/booking/booking_model.dart';
import '../../../models/entities/index.dart';
import '../../../models/index.dart'
    show AppModel, CartModel, Order, PaymentMethodModel, TaxModel, UserModel;
import '../../../modules/native_payment/index.dart';
import '../../../services/index.dart';

class PaymentMethods extends StatefulWidget {
  final Function? onBack;
  final Function? onFinish;
  final Function(bool)? onLoading;

  const PaymentMethods({this.onBack, this.onFinish, this.onLoading});

  @override
  _PaymentMethodsState createState() => _PaymentMethodsState();
}

class _PaymentMethodsState extends State<PaymentMethods> {
  String? selectedId;
  bool isPaying = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      final cartModel = Provider.of<CartModel>(context, listen: false);
      final userModel = Provider.of<UserModel>(context, listen: false);
      Provider.of<PaymentMethodModel>(context, listen: false).getPaymentMethods(
          cartModel: cartModel,
          shippingMethod: cartModel.shippingMethod,
          token: userModel.user != null ? userModel.user!.cookie : null);

      if (kPaymentConfig['EnableReview'] != true) {
        Provider.of<TaxModel>(context, listen: false)
            .getTaxes(Provider.of<CartModel>(context, listen: false),
                (taxesTotal, taxes) {
          Provider.of<CartModel>(context, listen: false).taxesTotal =
              taxesTotal;
          Provider.of<CartModel>(context, listen: false).taxes = taxes;
          setState(() {});
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartModel = Provider.of<CartModel>(context);
    final currencyRate = Provider.of<AppModel>(context).currencyRate;
    final paymentMethodModel = Provider.of<PaymentMethodModel>(context);
    final taxModel = Provider.of<TaxModel>(context);

    return ListenableProvider.value(
        value: paymentMethodModel,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(S.of(context).paymentMethods,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 5),
            Text(
              S.of(context).chooseYourPaymentMethod,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ),
            ),
            Services().widget.renderPayByWallet(context),
            const SizedBox(height: 20),
            Consumer<PaymentMethodModel>(builder: (context, model, child) {
              if (model.isLoading) {
                return SizedBox(height: 100, child: kLoadingWidget(context));
              }

              if (model.message != null) {
                return SizedBox(
                  height: 100,
                  child: Center(
                      child: Text(model.message!,
                          style: const TextStyle(color: kErrorRed))),
                );
              }

              if (selectedId == null && model.paymentMethods.isNotEmpty) {
                selectedId =
                    model.paymentMethods.firstWhere((item) => item.enabled!).id;
              }
              return Column(
                children: <Widget>[
                  for (int i = 0; i < model.paymentMethods.length; i++)
                    model.paymentMethods[i].enabled!
                        ? Services().widget.renderPaymentMethodItem(
                            context, model.paymentMethods[i], (i) {
                            setState(() {
                              selectedId = i;
                            });
                          }, selectedId)
                        : Container()
                ],
              );
            }),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).subtotal,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.8),
                    ),
                  ),
                  Text(
                      PriceTools.getCurrencyFormatted(
                          cartModel.getSubTotal(), currencyRate,
                          currency: cartModel.currency)!,
                      style: const TextStyle(fontSize: 14, color: kGrey400))
                ],
              ),
            ),
            Services().widget.renderShippingMethodInfo(context),
            if (selectedId == 'ps_cashondelivery' &&
                cartModel.getSubTotal()! < 50)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      paymentMethodModel.paymentMethods
                              .firstWhere((element) =>
                                  element.id == 'ps_cashondelivery')
                              .title ??
                          '',
                      style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    Text(
                      PriceTools.getCurrencyFormatted(
                          environment['cod_cost'].toString(), currencyRate,
                          currency: cartModel.currency)!,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                    )
                  ],
                ),
              ),
            if (cartModel.getCoupon() != '')
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      S.of(context).discount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.8),
                      ),
                    ),
                    Text(
                      cartModel.getCoupon(),
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .secondary
                                .withOpacity(0.8),
                          ),
                    )
                  ],
                ),
              ),
            Services().widget.renderTaxes(taxModel, context),
            Services().widget.renderRewardInfo(context),
            Services().widget.renderCheckoutWalletInfo(context),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    S.of(context).total,
                    style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
                  Text(
                    PriceTools.getCurrencyFormatted(
                        selectedId != 'ps_cashondelivery' ||
                                cartModel.getSubTotal()! >= 50
                            ? cartModel.getTotal()
                            : cartModel.getTotal()! + environment['cod_cost'],
                        currencyRate,
                        currency: cartModel.currency)!,
                    style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                child: SizedBox(
                  height: 45,
                  child: TextButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      elevation: 0,
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    onPressed: () async {
                      try {
                        if (isPaying || selectedId == null) {
                          showSnackbar();
                        } else {
                          placeOrder(paymentMethodModel, cartModel);
                        }
                      } catch (e) {
                        Tools.showSnackBar(Scaffold.of(context), e.toString());
                      }
                    },
                    child: Text(S.of(context).placeMyOrder.toUpperCase()),
                  ),
                ),
              ),
            ]),
            if (kPaymentConfig['EnableShipping'] ||
                kPaymentConfig['EnableAddress'] ||
                (kPaymentConfig['EnableReview'] ?? true))
              Center(
                child: TextButton(
                  onPressed: () {
                    isPaying ? showSnackbar : widget.onBack!();
                  },
                  child: Text(
                    Localizations.localeOf(context).languageCode == 'en'
                        ? 'Back'
                        : 'Πίσω',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 15,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              )
          ],
        ));
  }

  void showSnackbar() {
    Tools.showSnackBar(
        Scaffold.of(context), S.of(context).orderStatusProcessing);
  }

  void placeOrder(PaymentMethodModel paymentMethodModel, CartModel cartModel) {
    widget.onLoading!(true);
    isPaying = true;
    if (paymentMethodModel.paymentMethods.isNotEmpty) {
      final paymentMethod = paymentMethodModel.paymentMethods
          .firstWhere((item) => item.id == selectedId);
      Provider.of<CartModel>(context, listen: false)
          .setPaymentMethod(paymentMethod);

      /// Use Native payment
      if (paymentMethod.id!.contains('paypal')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaypalPayment(
              onFinish: (number) async {
                printLog(':::::::: PaypalPayment with  onFinish=> $number');
                if (number == null) {
                  widget.onLoading!(false);
                  isPaying = false;
                  return;
                } else {
                  await createOrder(paid: true).then((value) {
                    widget.onLoading!(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );
      } else if (paymentMethod.id!.contains('vivapay')) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VivaPayment(
              onFinish: (number) {
                if (number == null) {
                  widget.onLoading!(false);
                  isPaying = false;
                  return;
                } else {
                  createOrder(paid: true).then((value) {
                    widget.onLoading!(false);
                    isPaying = false;
                  });
                }
              },
            ),
          ),
        );
      } else {
        /// Use WebView Payment per frameworks

        try {
          Services().widget.placeOrder(
            context,
            cartModel: cartModel,
            onLoading: widget.onLoading,
            paymentMethod: paymentMethod,
            success: (Order? order) async {
              if (order != null) {
                for (var item in order.lineItems) {
                  Product? product = cartModel.getProductById(item.productId!)!;
                  if (product.bookingInfo != null) {
                    product.bookingInfo!.idOrder = item.id;
                    var booking = await createBooking(product.bookingInfo);

                    Tools.showSnackBar(Scaffold.of(context),
                        booking! ? 'Booking success!' : 'Booking error!');
                  }
                }
                widget.onFinish!(order);
              }
              widget.onLoading!(false);
              isPaying = false;
            },
            error: (message) {
              widget.onLoading!(false);
              if (message != null) {
                logger.d(message);
                Tools.showSnackBar(Scaffold.of(context), message);
              }

              isPaying = false;
            },
          );
        } catch (e) {
          rethrow;
        }
      }
    }
  }

  Future<bool>? createBooking(BookingModel? bookingInfo) async {
    return Services().api.createBooking(bookingInfo)!;
  }

  Future<void> createOrder(
      {paid = false, bacs = false, cod = false, transactionId = ''}) async {
    await createOrderOnWebsite(
        paid: paid,
        bacs: bacs,
        cod: cod,
        transactionId: transactionId,
        onFinish: (Order? order) async {
          if (!transactionId.toString().isEmptyOrNull && order != null) {
            await Services()
                .api
                .updateOrderIdForRazorpay(transactionId, order.number);
          }
          widget.onFinish!(order);
        });
  }

  Future<void> createOrderOnWebsite(
      {paid = false,
      bacs = false,
      cod = false,
      transactionId = '',
      required Function(Order?) onFinish}) async {
    widget.onLoading!(true);
    await Services().widget.createOrder(
      context,
      paid: paid,
      cod: cod,
      bacs: bacs,
      transactionId: transactionId,
      onLoading: widget.onLoading,
      success: onFinish,
      error: (message) {
        Tools.showSnackBar(Scaffold.of(context), message);
      },
    );
    widget.onLoading!(false);
  }
}
