--Beasts of Phantom
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
	--Checks if Chimera was Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_STARTUP)
        e1:SetRange(0x5f)
        e1:SetCountLimit(1)
        e1:SetOperation(s.op) 
        c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
		aux.AddValuesReset(function()
        		s[0]=0
        		s[1]=0
		end)
	end)
end
s.listed_names={4796100} --"Chimera the Flying Mythical Beast"
s.listed_series={SET_PHANTOM_BEAST}
function s.op(e,tp,eg,ep,ev,re,r,rp)
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE+PHASE_END)
        e1:SetCountLimit(1)
        e1:SetCondition(s.flipcon2)
        e1:SetOperation(s.flipop2)
        Duel.RegisterEffect(e1,tp)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for tc in eg:Iter() do
		if tc:IsCode(4796100) and tc:IsSummonType(SUMMON_TYPE_FUSION) then
			local p=tc:GetSummonPlayer()
			s[p]=s[p]+1
		end
	end
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,4796100),extrafil=s.fextra(c)}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and s.cost(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,4796100),extrafil=s.fextra(c)}
	--You can only apply this effect once per turn
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	--Discard 1 card
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	--Fusion Summon "Chimera the King of Mythical Beasts", using monsters from your hand or field as material
	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end
function s.fextra(exc)
	return function(e,tp,mg)
		return nil,s.fcheck(exc)
	end
end
function s.fcheck(exc)
	return function(tp,sg,fc)
		return not (exc and sg:IsContains(exc))
	end
end
--Add "Phantom Beast" card to hand
function s.thfilter(c)
	return c:IsSetCard(SET_PHANTOM_BEAST) and c:IsMonster() and c:IsAbleToHand()
end
function s.flipcon2(e,tp,eg,ep,ev,re,r,rp)
	return (s[tp]>0 or s[1-tp]>0) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.GetTurnPlayer()==tp and not Duel.HasFlagEffect(tp,id+100)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	--Add 1 "Phantom Beast" monster from your GY to  your hand
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
	--Fusion Summon effect
	if not (Duel.IsMainPhase() and aux.CanActivateSkill(tp) and Duel.GetTurnPlayer()==tp and s.cost(e,tp,eg,ep,ev,re,r,rp,0)) then return end
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,4796100),extrafil=s.fextra(c)}
	--You can only apply this effect once per turn
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
	--Discard 1 card
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	--Fusion Summon "Chimera the King of Mythical Beasts", using monsters from your hand or field as material
	Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
	Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
end
