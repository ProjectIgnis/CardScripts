--Symbol of Pride
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
s.listed_names={CARD_BLUEEYES_W_DRAGON,23995346} --"Blue-Eyes Ultimate Dragon"
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	local c=e:GetHandler()
	--Tribute Summon "Blue-Eyes White Dragon" using 1 Tribute Summoned monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(0x5f)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCondition(s.otcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.ottg,s.sumtg))
	e1:SetOperation(s.otop)
	e1:SetCountLimit(1)
	e1:SetValue(SUMMON_TYPE_TRIBUTE)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	Duel.RegisterEffect(e2,tp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(0x5f)
	e3:SetCondition(s.extrasumcon)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsCode,CARD_BLUEEYES_W_DRAGON))
	e3:SetValue(0x1)
	Duel.RegisterEffect(e3,tp)
	--Choose 1 of these Skills to activate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(0x5f)
	e4:SetTarget(s.efftg)
	e4:SetOperation(s.effop)
	Duel.RegisterEffect(e4,tp)
end
function s.relrepfilter(c)
	return c:IsTributeSummoned() and c:IsReleasable()
end
function s.extrasumcon(e)
	return Duel.IsExistingMatchingCard(s.relrepfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	return minc<=2 and Duel.IsExistingMatchingCard(s.relrepfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.ottg(e,c)
	local mi,ma=c:GetTributeRequirement()
	return mi<=2 and ma>=2 and c:IsCode(CARD_BLUEEYES_W_DRAGON)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.relrepfilter,tp,LOCATION_MZONE,0,1,1,true,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if not sg then return end
	Duel.Release(sg,REASON_SUMMON|REASON_MATERIAL,tp)
	sg:DeleteGroup()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,23995346),stage2=s.stage2}
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsMonster,nil)
	local b1=#g>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_BLUEEYES_W_DRAGON),tp,LOCATION_MZONE,0,1,nil) and not Duel.HasFlagEffect(tp,id)
	local b2=Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,0) and not Duel.HasFlagEffect(tp,id+100)
	--condition
	if chk==0 then return aux.CanActivateSkill(tp) and Duel.IsExistingMatchingCard(aux.AND(Card.IsSpell,Card.IsDiscardable),tp,LOCATION_HAND,0,1,nil) and (b1 or b2) end
	--Discard 1 Spell
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	Duel.DiscardHand(tp,aux.AND(Card.IsSpell,Card.IsDiscardable),1,1,REASON_COST|REASON_DISCARD)
	--Choose Effect(Destroy monsters, Fusion Summon BEUD)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	Duel.SetPossibleOperationInfo(0,CATEGORY_FUSION_SUMMON,nil,1,tp,0)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local params={fusfilter=aux.FilterBoolFunction(Card.IsCode,23995346),stage2=s.stage2}
	local op=e:GetLabel()
	if op==1 then
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id,0,0,0)
		--Destroy all monsters your opponent controls
		local dg=Duel.GetMatchingGroup(Card.IsMonster,tp,0,LOCATION_MZONE,nil)
		Duel.Destroy(dg,REASON_EFFECT)
		--"Blue-Eyes White Dragon" you control cannot attack for the rest of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(CARD_BLUEEYES_W_DRAGON) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		--You can only use this Skill once per Duel
		Duel.RegisterFlagEffect(tp,id+100,0,0,0)
		--Fusion Summon "Blue-Eyes Ultimate Dragon"
		Fusion.SummonEffTG(params)(e,tp,eg,ep,ev,re,r,rp,1)
		Fusion.SummonEffOP(params)(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.stage2(e,tc,tp,sg,chk)
	if chk==0 then
		--Unaffected by your opponent's card effects this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(function(e,te) return te:GetOwnerPlayer()~=e:GetHandlerPlayer() end)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end
