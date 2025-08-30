--天地諧謔のコスモス姫
--Princess Cosmos the Cosmic Trickster
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Materials
	c:EnableReviveLimit()
	Fusion.AddProcMixRep(c,true,true,s.matfilter,2,99,160216046)
	--Destroy 1 card your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--Material Check
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.sumcond)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
end
s.named_material={160216046}
function s.matfilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_GALAXY,fc,sumtype,tp) and c:IsAttack(900)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		if c:GetFlagEffect(id)>0 then
			return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		end
		return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,nil) 
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Effect
	if c:GetFlagEffect(id)>0 then
		local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
		g=g:AddMaximumCheck()
		Duel.Destroy(g,REASON_EFFECT)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,1,1,nil)
		local dg2=dg:AddMaximumCheck()
		Duel.HintSelection(dg2)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
function s.sumcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=c:GetMaterial()
	if #g>=9 then
		c:RegisterFlagEffect(id,RESET_EVENT|(RESETS_STANDARD&~RESET_TOFIELD),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
end