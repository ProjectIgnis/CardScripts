--大いなる魔導
--Theologia Magistus
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x24b}
function s.tgfilter(c,tp,check)
	return c:IsFaceup() and c:IsSetCard(0x24b) and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,0,1,c,check)
end
function s.eqfilter(c,check)
	return not c:IsForbidden() and c:IsType(TYPE_MONSTER)
		and ((check and c:IsLocation(LOCATION_EXTRA) and c:IsType(TYPE_EXTRA)) or (c:IsSetCard(0x24b) and not c:IsLevel(4)))
end
function s.chkfilter(c,typ)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x24b) and c:IsType(typ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local check=Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_FUSION)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_SYNCHRO)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_LINK)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.tgfilter(chkc,tp,check) end
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=ft-1 end
	if chk==0 then return ft>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp,check) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,check)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local check=Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_FUSION)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_SYNCHRO)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_XYZ)
		and Duel.IsExistingMatchingCard(s.chkfilter,tp,LOCATION_GRAVE,0,1,nil,TYPE_LINK)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_EXTRA+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,tc,check)
	local eq=g:GetFirst()
	if eq then
		Duel.Equip(tp,eq,tc,true)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(tc)
		eq:RegisterEffect(e1)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end