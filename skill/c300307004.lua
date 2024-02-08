--Insect Infestation
--Scripted by the Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
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
s.listed_names={27911549}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--"Parasite Paracide" on field cannot be Tributed
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetRange(0x5f)
	e1:SetTarget(function(e,c) return c:IsCode(27911549) and c:IsFaceup() end)
	e1:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e1:SetValue(1)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	Duel.RegisterEffect(e2,tp)
	--Level 7 or higher Insect monsters you control can direct attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DIRECT_ATTACK)
	e3:SetRange(0x5f)
	e3:SetCondition(s.atkcon)
	e3:SetTarget(function(e,c) return c:IsMonster() and c:IsLevelAbove(7) and c:IsRace(RACE_INSECT) end)
	e3:SetTargetRange(LOCATION_MZONE,0)
	Duel.RegisterEffect(e3,tp)
	--Place 1 "Parasite Paracide" from your GY face-up on opponent's Deck as if it were placed by its own effect
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(0x5f)
	e4:SetCondition(s.ppcon)
	e4:SetOperation(s.ppop)
	Duel.RegisterEffect(e4,tp)
end
--Direct Attack functions
function s.cfilter(c)
	return c:IsMonster() and c:IsFaceup() and c:IsRace(RACE_INSECT)
end
function s.atkcon(e)
	local g=Duel.GetFieldGroup(0,LOCATION_MZONE,LOCATION_MZONE)
	local fg=g:Filter(s.cfilter,nil)
	return #g==#fg
end
--"Parasite Paracide" placement functions
function s.ppfilter(c)
	return c:IsCode(27911549) and c:IsAbleToDeck()
end
function s.ppcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and Duel.GetFlagEffect(tp,id)==0
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsExistingMatchingCard(s.ppfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.ppop(e,tp,eg,ep,ev,re,r,rp)
	--OPD Register
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Discard 1 add to place "Parasite Paracide" on opponent's Deck
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local ct=Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,nil)
	if ct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local sg=Duel.SelectMatchingCard(tp,s.ppfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #sg>0 then
			local c=sg:GetFirst()
			Duel.SendtoDeck(sg,1-tp,SEQ_DECKTOP,REASON_EFFECT)
			if not c:IsLocation(LOCATION_DECK) then return end
			c:ReverseInDeck()
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(27911549,1))
			e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
			e1:SetCode(EVENT_DRAW)
			e1:SetTarget(s.sptg)
			e1:SetOperation(s.spop)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD&~RESET_TOHAND)
			c:RegisterEffect(e1)
		end
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		Duel.Damage(tp,1000,REASON_EFFECT)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(RACE_INSECT)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end