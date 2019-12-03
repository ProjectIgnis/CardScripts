--エターナル・ドレッド
--Eternal Dread
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.addcon)
	e1:SetOperation(s.addc)
	c:RegisterEffect(e1)
end
s.counter_place_list={0x1b}
s.listed_names={75041269}
function s.check(tp)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	return tc and tc:IsFaceup() and tc:IsCode(75041269)
end
function s.addcon(e,tp,eg,ep,ev,re,r,rp)
	return s.check(0) or s.check(1)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_SZONE,5)
	if tc and tc:IsFaceup() and tc:IsCode(75041269) then
		tc:AddCounter(0x1b,2)
	end
	tc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	if tc and tc:IsFaceup() and tc:IsCode(75041269) then
		tc:AddCounter(0x1b,2)
	end
end
