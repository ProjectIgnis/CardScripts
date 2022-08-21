--Magnetic Attraction
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.flipcon2)
	e1:SetOperation(s.flipop2)
	Duel.RegisterEffect(e1,tp)
end
s.listed_series={0x2066}
s.listed_names={75347539}
--reveal 
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,2,nil)
		and Duel.IsExistingMatchingCard(s.thfilter1,tp,LOCATION_DECK,0,1,nil,75347539)
end
function s.revfilter(c)
	return c:IsSetCard(0x2066) and c:IsMonster() and not c:IsPublic()
end
function s.thfilter1(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.rescon(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetCode)>1
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local hg=Duel.GetMatchingGroup(s.revfilter,tp,LOCATION_HAND,0,nil)
	local g=aux.SelectUnselectGroup(hg,e,tp,2,2,aux.dncheck,1,tp,HINTMSG_CONFIRM)
	if #g==2 then
		Duel.ConfirmCards(1-tp,g)
		local g1=Duel.SelectMatchingCard(tp,s.thfilter1,tp,LOCATION_DECK,0,1,1,nil,75347539)
		if #g1>0 then
			Duel.SendtoHand(g1,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g1)
			Duel.ShuffleHand(tp)
		end
	end
end
----If a magnet warrior monster is normal summoned
function s.thcfilter(c,tp)
	local code=c:GetCode()
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsLocation(LOCATION_MZONE) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,code)
end
function s.thfilter2(c,code)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsMonster() and c:IsAbleToHand() and not c:IsCode(code)
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	--opd check
	if Duel.GetFlagEffect(ep,id+1)>0 then return end
	return eg:IsExists(s.thcfilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil,code)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		--opd register
		Duel.RegisterFlagEffect(ep,id+1,0,0,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil,eg:GetFirst():GetCode())
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end