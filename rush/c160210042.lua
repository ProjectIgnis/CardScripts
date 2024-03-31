--伝導士アルケミカライザー・スイライ
--Conduction Warrior Alchemicalizer Suirai
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),aux.FilterBoolFunction(Card.IsRace,RACE_THUNDER),true)
	--Gain ATK equal to the sum of the sent monsters' levels x 100
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,e:GetHandler(),1,tp,100)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(Card.IsMonster,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,nil)
	if #g==0 then return end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,math.min(3,#g),s.rescon,1,tp,HINTMSG_TOGRAVE,s.rescon)
	if #tg>0 and Duel.SendtoGrave(tg,REASON_COST)>0 then
		local og=Duel.GetOperatedGroup():Filter(aux.AND(Card.IsLocation,Card.IsMonster),nil,LOCATION_GRAVE)
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		--Gain 100 ATK x total level of the sent monsters
		local lv=og:GetSum(Card.GetLevel)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END,2)
		e1:SetValue(lv*100)
		c:RegisterEffect(e1)
		if #og==3 and og:GetClassCount(Card.GetRace)==3 then
			--Cannot be destroyed by your opponent's card effects
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(3060)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e2:SetValue(aux.indoval)
			e2:SetReset(RESETS_STANDARD_PHASE_END,2)
			c:RegisterEffect(e2)
		end
	end
end