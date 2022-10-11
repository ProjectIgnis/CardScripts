--ライトウェーブ・ドラゴン
--Lightwave Dragon
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- atk change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
end
function s.atkfilter(c)
	return c:IsMonster() and c:IsFaceup() and c:GetAttack()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,e:GetHandler()) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,2,REASON_COST)==2 then
		--Effect
		local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.atkfilter),tp,0,LOCATION_MZONE,1,3,nil)
			if #g2>0 then
				Duel.HintSelection(g2,true)
				for tc in g2:Iter() do
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_UPDATE_ATTACK)
					e1:SetValue(-1500)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_MAIN1)
					tc:RegisterEffectRush(e1)
				end
			end
		end
	end
end
