--Ultimate Wizardry
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop2)
	c:RegisterEffect(e1)
end
s.counter_place_list={COUNTER_SPELL}
function s.filter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_SPELLCASTER)and c:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	return aux.CanActivateSkill(tp) and #g>0
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Place 1 Spell Counter on all Spellcasters
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	for tc in g:Iter() do
		tc:AddCounter(COUNTER_SPELL,1)
	end
	Duel.RegisterFlagEffect(tp,id,0,0,0)
end
function s.flipop2(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ctcon)
	e1:SetOperation(s.ctop)
	Duel.RegisterEffect(e1,tp)
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	return aux.CanActivateSkill(tp) and #g>0 and Duel.GetFlagEffect(tp,id)>0
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if #sg>0 then
		sg:GetFirst():AddCounter(COUNTER_SPELL,1)
	end
end