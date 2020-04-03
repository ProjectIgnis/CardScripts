--神鳥の烈戦
--Simorgh Storms Forth
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
	--Cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.atlimit)
	e3:SetValue(s.evalue)
	c:RegisterEffect(e3)
	--To hand
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
s.listed_series={0x12d}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if s.thcost(e,tp,eg,ep,ev,re,r,rp,0) and s.thtg(e,tp,eg,ep,ev,re,r,rp,0)
		and Duel.SelectYesNo(tp,94) then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
		s.thcost(e,tp,eg,ep,ev,re,r,rp,1)
		s.thtg(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetOperation(s.thop)
	else
		e:SetCategory(0)
		e:SetOperation(nil)
	end
end
function s.atkval(tp)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsRace,RACE_WINGEDBEAST),tp,LOCATION_MZONE,0,nil)
	local _,val=g:GetMaxGroup(Card.GetAttack)
	return val
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsRace(RACE_WINGEDBEAST) and c:GetAttack()<s.atkval(e:GetHandlerPlayer())
end
function s.evalue(e,re,rp)
	return rp~=e:GetHandlerPlayer()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsSetCard(0x12d) and c:IsLevelAbove(7)
end
function s.rescon(sg,e,tp,mg) 
	return sg:GetClassCount(Card.GetOriginalAttribute)==#sg and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,sg+e:GetHandler()) 
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return e:GetLabel()==100 and c:IsAbleToGraveAsCost() and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0) end
	local tg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_TOGRAVE)
	tg:AddCard(c)
	Duel.SendtoGrave(tg,REASON_COST)
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_HAND)
		if #og>0 then
			local dam=Duel.Damage(tp,#og*500,REASON_EFFECT)
			if dam>0 then
				Duel.BreakEffect()
				Duel.Damage(1-tp,dam,REASON_EFFECT)
			end
		end
	end
end