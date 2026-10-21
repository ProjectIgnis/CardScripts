--コスモス姫のお召し替え
--Princess Cosmos' Change of Clothes
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--This card's name becomes "Princess Cosmos' Jest" while in the hand
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_HAND)
	e0:SetValue(160017058)
	c:RegisterEffect(e0)
	--Destroy 1 face-up Galaxy Type monster with 900 original ATK on your field. Then, if you have not drawn a card by the effect of "Princess Cosmos' Change of Clothes" this turn, you can draw 2 cards.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={160017058} --"Princess Cosmos' Jest"
function s.desfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsBaseAttack(900) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,1,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	if #dg>0 then
		Duel.HintSelection(dg)
		if Duel.Destroy(dg,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,2)
			and not Duel.HasFlagEffect(tp,id)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			if Duel.Draw(tp,2,REASON_EFFECT)>0 then
				--Register if you drew by this effect of "Princess Cosmos' Change of Clothes" 
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
			end
		end
	end
end
