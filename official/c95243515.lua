--電脳堺虎－虎々
--Virtual World Tiger - Fufu
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,9,2,nil,nil,Xyz.InfiniteMats)
	--Negate the effects of 2 monsters on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1)
	e1:SetCost(Cost.Detach(1,1,nil))
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1,false,REGISTER_FLAG_DETACH_XMAT)
	--Can attack directly
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.effcond(2))
	c:RegisterEffect(e2)
	--Unaffected by activated effects, except "Virtual World" cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.effcond(4))
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)
end
s.listed_series={SET_VIRTUAL_WORLD,SET_VIRTUAL_WORLD_GATE}
function s.effcond(value)
	return function(e)
		local ct=Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsSetCard,SET_VIRTUAL_WORLD_GATE),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)
		return (value==2 and ct>=value) or (value==4 and ct==value)
	end
end
function s.efilter(e,te)
	return te:IsActivated() and not te:GetOwner():IsSetCard(SET_VIRTUAL_WORLD)
end
function s.tgfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and not c:IsDisabled() and c:IsCanBeEffectTarget(e)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsControler,1,nil,tp) and sg:IsExists(s.propfilter,1,nil,sg:GetFirst())
end
function s.propfilter(c,sc)
	return sc and not c:IsRace(sc:GetRace()) and not c:IsAttribute(sc:GetAttribute())
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_NEGATE)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,tg,2,0,0)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetTargetCards(e)
	if #dg==0 then return end
	local c=e:GetHandler()
	for tc in dg:Iter() do
		if tc:IsFaceup() and not tc:IsDisabled() then
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			--Negate its effects
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
	end
end
