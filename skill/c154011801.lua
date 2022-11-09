--A Trick Up The Sleeve
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetCondition(s.flipcon)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:GetLevel()==7 and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.cfilter2(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(7) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_DECK,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd 
	if Duel.GetFlagEffect(tp,id)>0 then return end
	--Starting hand/Cannot Special Summon
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	local g=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_DECK,0,nil):RandomSelect(tp,1)
	local tc=g:GetFirst()
	Duel.MoveSequence(tc,SEQ_DECKTOP)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.nscon)
	e1:SetTarget(s.nstg)
	Duel.RegisterEffect(e1,tp)
end
function s.nscon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnCount()<3 and Duel.GetTurnPlayer()==tp
end
function s.nstg(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsType(TYPE_EFFECT)
end
