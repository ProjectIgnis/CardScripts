--氷結界の霜精
--Hexa Spirit of the Ice Barrier
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Decrease ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Change Level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_LVCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_ICE_BARRIER}
function s.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_ICE_BARRIER) and c:IsMonster()
end
function s.atkcon(e,tp,ev,ep,eg,re,r,rp)
	return Duel.IsExistingMatchingCard(s.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.tgfilter(c,lv)
	return c:IsLevelBelow(3) and c:IsSetCard(SET_ICE_BARRIER) and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,e:GetHandler(),1,0,0)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_GRAVE) then
		local c=e:GetHandler()
		if not (c:IsRelateToEffect(e) and c:IsFaceup()) then return end
		--Change Level
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	end
end