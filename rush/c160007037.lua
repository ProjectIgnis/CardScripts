-- 報道艦轟鎧號 疾風迅雷
-- Lightning Speed, the Rumbling Report Warship
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,CARD_TOUGHROID,CARD_WHIRR)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(1-tp,7) end
end
function s.filter(c)
	return c:IsType(TYPE_MONSTER)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	if not Duel.IsPlayerCanDiscardDeck(1-tp,7) or Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--effect
	local c=e:GetHandler()
	Duel.ConfirmDecktop(1-tp,7)
	local g=Duel.GetDecktopGroup(1-tp,7)
	local sg=g:Filter(s.filter,nil)
	if #sg>0 then
		local val=#sg*(-500)
	end
	Duel.MoveToDeckBottom(7,1-tp)
	Duel.SortDeckbottom(1-tp,1-tp,7)
	local g2=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.filter2),tp,0,LOCATION_MZONE,nil)
	if #g2==0 then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		for tc in g2:Iter() do
		--Decrease ATK
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(val)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffectRush(e2)
		end
	end
end
function s.filter2(c)
	return c:IsFaceup()
end