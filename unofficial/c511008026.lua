--グランエルＴ５
--Granel Top 5
--Scripted by Snrk
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Destroy itself
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(s.sdcon)
	c:RegisterEffect(e1)
	--Equip
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.eqcon)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
s.listed_series={0x562}
function s.sdcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsInfinity),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToChangeControler()
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.eqfilter,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsInfinity),tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local eqc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsInfinity),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local eqtg=Duel.SelectMatchingCard(tp,s.eqfilter,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if not eqg or not eqtgc then return end
	if Duel.Equip(tp,eqtg,eqc,false) then
		--add equip limit
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(true)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		eqtg:RegisterEffect(e1)
	else
		Duel.SendtoGrave(eqtg,REASON_EFFECT)
	end
end