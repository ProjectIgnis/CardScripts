--ドラグニティナイトの影霊衣
--Nekroz of Areadbhair
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Must be ritual summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	--Tribute up to 2 "Nekroz" monsters, send that many "Nekroz" cards from deck to GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	--Negate the activation of monster effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.negcon)
	e3:SetCost(s.negcost)
	e3:SetTarget(s.negtg)
	e3:SetOperation(s.negop)
	c:RegisterEffect(e3)
end
	--Lists "Nekroz" archetype
s.listed_series={0xb4}

	--Cannot include level 10 monsters for its ritual summon
function s.mat_filter(c)
	return c:GetLevel()~=10
end
	--Discard itself as cost
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
	--Check for "Nekroz" monsters to tribute
function s.filter(c)
	return c:IsSetCard(0xb4) and c:IsType(TYPE_MONSTER) and c:IsReleasableByEffect()
end
	--Check for "Nekroz" cards to send to GY
function s.sendfilter(c)
	return c:IsSetCard(0xb4) and c:IsAbleToGrave()
end
	--Activation legality
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sendfilter,tp,LOCATION_DECK,0,1,nil)
		and Duel.CheckReleaseGroupEx(tp,s.filter,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
	--Tribute up to 2 "Nekroz" monsters, send that many "Nekroz" cards from deck to GY
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ac=Duel.GetMatchingGroupCount(s.sendfilter,tp,LOCATION_DECK,0,nil)
	if ac==0 then return end
	if ac>2 then ac=2 end
	local g=Duel.SelectReleaseGroupEx(tp,s.filter,1,ac,nil)
	if g and #g>0 then
		Duel.HintSelection(g)
		local rct=Duel.Release(g,REASON_EFFECT)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg=Duel.SelectMatchingCard(tp,s.sendfilter,tp,LOCATION_DECK,0,rct,rct,nil)
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
	--Monster effect activated
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
	--Tribute 1 monster from hand or field as cost
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,1,true,nil,nil) end
	local sg=Duel.SelectReleaseGroupCost(tp,nil,1,1,true,nil,nil)
	Duel.Release(sg,REASON_COST)
end
	--Activation legality
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsAbleToRemove() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,eg,1,0,0)
	end
end
	--Negate the activation of monster effect, and if you do, banish that card
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)
	end
end