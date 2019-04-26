--Sayuri-Cosmic Truth
local m=210765920
local cm=_G["c"..m]
xpcall(function() require("expansions/script/c210765765") end,function() require("script/c210765765") end)
cm.Senya_name_with_sayuri=true
function cm.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,m+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(cm.target)
	e1:SetOperation(cm.activate)
	c:RegisterEffect(e1)
end
function cm.filter(c,e,tp,eg,ep,ev,re,r,rp)
	local te=Senya.sayuri_activate_effect[c]
	if not (Senya.check_set_sayuri(c) and c:GetType()==0x82 and te and c:IsAbleToDeck()) then return false end
	local tg=te:GetTarget()
	return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)
end
function cm.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and cm.filter(chkc,e,tp,eg,ep,ev,re,r,rp) end
	if chk==0 then return Duel.IsExistingTarget(cm.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cm.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	local tg=Senya.sayuri_activate_effect[tc]:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
end
function cm.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local te=Senya.sayuri_activate_effect[tc]
	if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)>0 and te then
		Duel.ShuffleDeck(tc:GetControler())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end