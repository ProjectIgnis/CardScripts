--Red-Eye Inferno
--Scripted by The Razgriz
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
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_REDEYES_B_DRAGON}
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Tribute Summon "Red-Eyes Black Dragon" using 1 less Tribute for each monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetTarget(function(e,c) return c:IsCode(CARD_REDEYES_B_DRAGON) end)
	e1:SetValue(s.tribval)
	Duel.RegisterEffect(e1,tp)
	--Choose 1 of these Skills to activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(0x5f)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	Duel.RegisterEffect(e2,tp)
end
function s.tribval(e,c)
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),0,LOCATION_MZONE):Filter(Card.IsMonster,nil)
	return #g
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_REDEYES_B_DRAGON),stage2=s.stage2}
	local b1=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_REDEYES_B_DRAGON),tp,LOCATION_MZONE,0,1,nil) and not Duel.HasFlagEffect(tp,id)
	local b2=Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+100)
	--condition
	if chk==0 then return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.AND(Card.IsSpell,Card.IsDiscardable),tp,LOCATION_HAND,0,1,nil) and (b1 or b2) end
	--Discard 1 Spell
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.DiscardHand(tp,aux.AND(Card.IsSpell,Card.IsDiscardable),1,1,REASON_COST|REASON_DISCARD)
	--Choose Effect(Inflict damage, Fusion Summon 1 Fusion Monster)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local params={fusfilter=aux.FilterBoolFunction(Card.ListsCodeAsMaterial,CARD_REDEYES_B_DRAGON),stage2=s.stage2}
	local op=e:GetLabel()
	if op==1 then
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Inflict 800 damage to your opponent
		Duel.Damage(1-tp,800,REASON_EFFECT)
		--"Red-Eyes Black Dragon" you control cannot attack for the rest of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(CARD_REDEYES_B_DRAGON) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		--Fusion Summon 1 Fusion Monster that lists "Red-Eyes Black Dragon" as material
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Cannot be destroyed by your opponent's card effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(aux.indoval)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
