--タマーボット・バーストドラゴン
--Tamabot Burst Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_BLUETOOTH_B_DRAGON,CARD_TAMABOT)
	-- Gain 500 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BLUETOOTH_B_DRAGON,CARD_TAMABOT}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,e:GetHandlerPlayer(),LOCATION_GRAVE,LOCATION_GRAVE,nil,CARD_TAMABOT)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeckAsCost(tp,ct) end
end
function s.desfilter(c)
	return c:IsAttackAbove(1500) and c:IsFaceup()
end
function s.filter(c)
	return c:IsMonster() and c:IsAttackBelow(1500) and c:IsLocation(LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(Card.IsCode,c:GetControler(),LOCATION_GRAVE,LOCATION_GRAVE,nil,CARD_TAMABOT)
	if Duel.DiscardDeck(tp,ct,REASON_COST)==0 then return end
	local og=Duel.GetOperatedGroup()
	--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	local desg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	local ct2=og:FilterCount(s.filter,nil)
	if #desg>0 and ct2>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local tg=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,1,1,nil)
		if #tg>0 then
			tg=tg:AddMaximumCheck()
			Duel.HintSelection(tg,true)
			Duel.Destroy(tg,REASON_EFFECT)
		end
	end
end
