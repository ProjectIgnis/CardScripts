--束ねられし力
--Strength in Unity
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Check if a monster was Ritual or Fusion Summoned using "Blue-Eyes White Dragon" or "Dark Magician"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetRange(LOCATION_SZONE)
	e1:SetValue(s.valcheck)
	c:RegisterEffect(e1)
	--Banish 1 card from the opponent's field or GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmvcond)
	e2:SetTarget(s.rmvtg)
	e2:SetOperation(s.rmvop)
	c:RegisterEffect(e2)
	--Return 1 Level 7 or higher Normal Monster in your GY to your hand or Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,{id,1})
	e3:SetCost(Cost.SelfToGrave)
	e3:SetTarget(s.rettg)
	e3:SetOperation(s.retop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_BLUEEYES_W_DRAGON,CARD_DARK_MAGICIAN}
function s.matfilter(c,sc,sumtype,tp)
	return c:IsSummonCode(sc,sumtype,tp,CARD_BLUEEYES_W_DRAGON,CARD_DARK_MAGICIAN)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if not g or #g==0 then return end
	local tp=e:GetHandlerPlayer()
	local ritual=g:IsExists(s.matfilter,1,nil,c,SUMMON_TYPE_RITUAL,tp)
	local fusion=g:IsExists(s.matfilter,1,nil,c,SUMMON_TYPE_FUSION,tp)
	if ritual or fusion then
		local sumtype=(ritual and SUMMON_TYPE_RITUAL) or 0
		if fusion then
			sumtype=sumtype|SUMMON_TYPE_FUSION
		end
		c:RegisterFlagEffect(id,RESET_CHAIN,0,1,sumtype)
	end
end
function s.cfilter(c,tp)
	if not (c:HasFlagEffect(id) and c:IsSummonPlayer(tp) and c:IsSummonType({SUMMON_TYPE_RITUAL,SUMMON_TYPE_FUSION})) then return false end
	local sumtype=c:GetFlagEffectLabel(id)
	return sumtype==SUMMON_TYPE_RITUAL|SUMMON_TYPE_FUSION or c:IsSummonType(sumtype)
end
function s.rmvcond(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.rmvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD|LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,0)
end
function s.rmvop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
function s.retfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsLevelAbove(7) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.retfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.retfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.retfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,g,1,tp,0)
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	aux.ToHandOrElse(tc,tp,
		function(c) return tc:IsAbleToDeck() end,
		function(c) Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT) end,
		aux.Stringid(id,2)
	)
end