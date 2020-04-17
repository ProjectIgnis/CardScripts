--
--Plunder Patroll Parrrty
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--equip itself
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100,EFFECT_COUNT_CODE_DUEL)
	e2:SetTarget(s.eqptg)
	e2:SetOperation(s.eqpop)
	c:RegisterEffect(e2)
end
s.listed_series={0x13f}
function s.condition(e,tp,eg,ep,ev,re,r,rp,chk)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsSetCard,0x13f),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_EQUIP),tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct+1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,ct,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_EQUIP),p,LOCATION_ONFIELD,0,nil)
	if ct>0 and Duel.IsPlayerCanDraw(p,ct+1) then
		if Duel.Draw(p,ct+1,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			local g=Duel.SelectMatchingCard(p,aux.TRUE,p,LOCATION_HAND,0,ct,ct,nil)
			Duel.ConfirmCards(1-p,g)
			Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
			Duel.ShuffleDeck(p)
		end
	end
end
function s.eqptgfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x13f) and c:IsSummonLocation(LOCATION_EXTRA) and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(tp)
end
function s.eqptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg and eg:IsExists(s.eqptgfilter,1,nil,tp) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.eqpop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or not eg then return end
	local tc=eg:FilterSelect(tp,s.eqptgfilter,1,1,nil,tp):GetFirst()
	if tc then
		s.equipop(tc,e,tp,e:GetHandler())
	end
end
function s.equipop(c,e,tp,tc)
	if not aux.EquipByEffectAndLimitRegister(c,e,tp,tc,nil,true) then return end
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlimit)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
function s.eqlimit(e,c)
	return c:GetControler()==e:GetHandlerPlayer()
end