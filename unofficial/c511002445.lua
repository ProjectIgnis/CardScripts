--Theft Whip
local s,id=GetID()
function s.initial_effect(c)
	--effect
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(0,TIMING_EQUIP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tcfilter(tc,ec,tp,eg,ep,ev,re,r,rp)
	if tc:IsFacedown() then return false end
	if ec:CheckEquipTarget(tc) then return true end
	local te=ec:GetActivateEffect()
	if te then
		local tg=te:GetTarget()
		return tg and tg(te,tp,eg,ep,ev,re,r,rp,0,tc)
	end
	return false
end
function s.ecfilter(c,tp,eg,ep,ev,re,r,rp)
	return c:IsType(TYPE_EQUIP) and c:GetEquipTarget()~=nil 
		and Duel.IsExistingMatchingCard(s.tcfilter,tp,LOCATION_MZONE,0,1,c:GetEquipTarget(),c,tp,eg,ep,ev,re,r,rp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.ecfilter,tp,0,LOCATION_SZONE,1,nil,tp,eg,ep,ev,re,r,rp) 
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(43641473,0))
	local g=Duel.SelectMatchingCard(tp,s.ecfilter,tp,0,LOCATION_SZONE,1,1,nil,tp,eg,ep,ev,re,r,rp)
	local tc=g:GetFirst()
	if tc then
		Duel.HintSelection(g)
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		local tg=Duel.SelectMatchingCard(tp,s.tcfilter,tp,LOCATION_MZONE,0,1,1,nil,tc,tp,eg,ep,ev,re,r,rp):GetFirst()
		Duel.Equip(tp,tc,tg)
	end
end
