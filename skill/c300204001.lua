--Ritual of Black Mastery
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop)
end
s.listed_names={5405694,30208479} --Black Luster Soldier, Magician of Black Chaos
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(5405694,30208479)
		and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsStatus(STATUS_SPSUMMON_TURN)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	--opt check
	if Duel.GetFlagEffect(ep,id)>0 then return end
	--condition
	return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	local c=e:GetHandler()
	--Black Luster Soldier cannot be destroyed by the opponent's Skill
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,5405694))
	e1:SetValue(s.efilter1)
	Duel.RegisterEffect(e1,tp)
	--Register a flag when a card is activated
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(aux.chainreg)
	Duel.RegisterEffect(e2,tp)
	--Draw 1 card after a Trap card activated by the opponent resolves
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetOperation(s.drop)
	Duel.RegisterEffect(e3,tp)
	--Magician of Black Chaos cannot be destroyed by your opponent's Spell effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetTargetRange(LOCATION_ONFIELD,0)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsCode,30208479))
	e4:SetValue(s.efilter2)
	Duel.RegisterEffect(e4,tp)
	--Add to the hand 1 Spell card from the GY
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	e5:SetCondition(s.thcon)
	e5:SetOperation(s.thop)
	Duel.RegisterEffect(e5,tp)
end
function s.efilter1(e,te)
	return te:GetHandlerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SKILL)
end
function s.efilter2(e,te)
	return te:GetHandlerPlayer()~=e:GetHandlerPlayer() and te:IsActiveType(TYPE_SPELL)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect() and re:GetHandlerPlayer()==1-tp
		and e:GetHandler():HasFlagEffect(1) and not Duel.HasFlagEffect(tp,id+1) then
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
function s.afilter(c,tp)
	return c:IsControler(tp) and c:IsCode(30208479)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp,chk)
	return eg:IsExists(s.afilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.filter(c)
	return c:IsSpell() and c:IsAbleToHand()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end