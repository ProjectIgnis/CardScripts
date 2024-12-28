--Powerful Group of Guys
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	Duel.AddCustomActivityCounter(id+100,ACTIVITY_NORMALSUMMON,function(c) return c:IsSetCard(SET_DESTINY_HERO) end)
    	Duel.AddCustomActivityCounter(id+200,ACTIVITY_SPSUMMON,function(c) return c:IsSetCard(SET_DESTINY_HERO) end)
    	Duel.AddCustomActivityCounter(id+300,ACTIVITY_FLIPSUMMON,function(c) return c:IsSetCard(SET_DESTINY_HERO) end)
end
s.listed_series={SET_DESTINY_HERO}
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(SET_DESTINY_HERO)
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,c:GetLevel(),e,tp)
end
function s.spfilter(c,lv,e,tp)
	return c:IsSetCard(SET_DESTINY_HERO) and c:GetLevel()<lv and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsMonster,nil)
	return aux.CanActivateSkill(tp) and #g1==1 and #g2>#g1
		and Duel.GetFlagEffect(tp,id)==0 and Duel.GetCustomActivityCount(id+100,tp,ACTIVITY_NORMALSUMMON)==0
        	and Duel.GetCustomActivityCount(id+200,tp,ACTIVITY_SPSUMMON)==0 and Duel.GetCustomActivityCount(id+300,tp,ACTIVITY_FLIPSUMMON)==0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--OPD register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Special Summon 1 "Destiny HERO" monster with a lower Level
	local tc=Duel.GetFieldGroup(tp,LOCATION_MZONE,0):GetFirst()
	local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tc:GetLevel(),e,tp)
	if #sg>0 then
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	--Cannot Summon monsters, except "Destiny HERO" monsters, the turn you activate this Skill
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsSetCard(SET_DESTINY_HERO) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	--Flip this card during the End Phase
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetRange(0x5f)
	e4:SetOperation(function(e,tp) Duel.Hint(HINT_SKILL_FLIP,tp,id|(2<<32)) end)
	Duel.RegisterEffect(e4,tp)
end
