--カオスエンド・ルーラー－開闢と終焉の支配者－
--Chaos End Ruler - Ruler of the Beginning and the End
--scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:AddMustBeSpecialSummoned()
	--Must be Special Summoned (from your hand) by banishing 1 LIGHT Warrior and 1 DARK Fiend monster from your GY
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	e0:SetTarget(s.sptg)
	e0:SetOperation(s.spop)
	e0:SetValue(9300)
	c:RegisterEffect(e0)
	--This card's Special Summon cannot be negated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	c:RegisterEffect(e1)
	--Neither player can activate cards or effects when this card is Special Summoned
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetOperation(s.limop)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_CHAIN_END)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e2b:SetOperation(function(e) e:GetHandler():ResetFlagEffect(id) Duel.SetChainLimitTillChainEnd(aux.FALSE) end)
	c:RegisterEffect(e2b)
	--If you control this card that was Summoned its own way: You can pay 1000 LP; banish as many cards from your opponent's field and GY as possible, then inflict 500 damage to your opponent for each card banished by this effect
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+9300) end)
	e3:SetCost(Cost.PayLP(1000))
	e3:SetTarget(s.bandamtg)
	e3:SetOperation(s.bandamop)
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
end
function s.spcostfilter(c)
	return ((c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR)) or (c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)))
		and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.propertyfilter(c,attribute,race)
	return c:IsAttribute(attribute) and c:IsRace(race)
end
function s.rescon(sg,e,tp,mg)
	return Duel.GetMZoneCount(tp,sg)>0 and sg:IsExists(s.propertyfilter,1,nil,ATTRIBUTE_LIGHT,RACE_WARRIOR)
		and sg:IsExists(s.propertyfilter,1,nil,ATTRIBUTE_DARK,RACE_FIEND)
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	return #g>=2 and Duel.GetMZoneCount(tp,g)>0 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.spcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,nil)
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_REMOVE,nil,nil,true)
	if #sg>0 then
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	if sg then
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end
function s.limop(e,tp,eg,ep,ev,re,r,rp)
	local current_chain=Duel.GetCurrentChain()
	if current_chain==0 then
		Duel.SetChainLimitTillChainEnd(aux.FALSE)
	elseif current_chain==1 then
		e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	end
end
function s.bandamtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,tp,LOCATION_ONFIELD|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
function s.damfilter(c)
	return c:IsLocation(LOCATION_REMOVED) and not c:IsReason(REASON_REDIRECT)
end
function s.bandamop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD|LOCATION_GRAVE,nil)
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		local damage=500*Duel.GetOperatedGroup():FilterCount(s.damfilter,nil)
		if damage>0 then
			Duel.Damage(1-tp,damage,REASON_EFFECT)
		end
	end
end