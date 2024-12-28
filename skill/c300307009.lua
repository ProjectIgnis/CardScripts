--The Dragon Hunting Swordsman
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
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BUSTER_BLADER}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Fusion Summon 1 Fusion Monster that lists "Buster Blader" as material
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(0x5f)
	e1:SetCondition(s.fuscon)
	e1:SetOperation(s.fusop)
	Duel.RegisterEffect(e1,tp)
	--Opponent's GY becomes Dragon monsters
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(0x5f)
	e2:SetTarget(function(e,c) return not c:IsRace(RACE_DRAGON) and c:IsMonster() end)
	e2:SetTargetRange(0,LOCATION_GRAVE)
	e2:SetCondition(s.racecon)
	e2:SetValue(RACE_DRAGON)
	Duel.RegisterEffect(e2,tp)
end
function s.costfilter(c,e,tp,eg,ep,ev,re,r,rp)
	if not c:IsDiscardable() then return false end
	local params={fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_BUSTER_BLADER),extrafil=s.fextra(c)}
	return Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp,eg,ep,ev,re,r,rp) end
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST|REASON_DISCARD,nil,e,tp,eg,ep,ev,re,r,rp)
end
function s.fuscon(e,tp,eg,ep,ev,re,r,rp)
	return aux.CanActivateSkill(tp) and s.cost(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id)
end
function s.fusop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local params={fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_BUSTER_BLADER),extrafil=s.fextra(c)}
	--You can only apply this effect once per Duel
	Duel.RegisterFlagEffect(tp,id,0,0,0)
	--Discard 1 card
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	--Fusion Summon 1 Fusion Monster that lists "Buster Blader" as material, using monsters from your hand or field as material
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
--Race Change Functions
function s.busterbladerfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_BUSTER_BLADER) or (c:IsType(TYPE_FUSION) and c:ListsCodeAsMaterial(CARD_BUSTER_BLADER)))
end
function s.racecon(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==1 and Duel.IsExistingMatchingCard(s.busterbladerfilter,tp,LOCATION_MZONE,0,1,nil)
end
