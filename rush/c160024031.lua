--ヴォイドヴェルグ・ビヨンドプローブ
--Voidvelg Beyond Probe
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160018001,1,s.ffilter,1)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,nil,nil,SUMMON_TYPE_FUSION,nil,false)
	--Destroy 1 face-down card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.named_material={160018001}
function s.ffilter(c,fc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,fc,sumtype,tp) and c:IsLevelBelow(4)
end
function s.contactfil(tp)
	return Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_ONFIELD,0,nil)
end
function s.contactop(g,tp)
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST+REASON_MATERIAL)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_STZONE,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local dg=Duel.GetMatchingGroup(Card.IsFacedown,tp,0,LOCATION_STZONE,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
	--Prevent non-DARK Galaxy from attacking
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.atktg(e,c)
	return not (c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK))
end
