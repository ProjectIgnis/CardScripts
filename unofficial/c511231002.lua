--N・アクア・ドルフィン
--Neo Spacian Aqua Dolphin (Anime)
--By Astral
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17955766,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
function s.filter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g>0 then
		Duel.ConfirmCards(tp,g)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17955766,1))
		local tg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_MONSTER)
		local tc=tg:GetFirst()
		if tc then
			local atk=tc:GetAttack()
			if atk>=0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,atk) then
				Duel.Destroy(tc,REASON_EFFECT)
				Duel.Damage(1-tp,500,REASON_EFFECT)
			else
				Duel.Damage(tp,500,REASON_EFFECT)
			end
		end
		Duel.ShuffleHand(1-tp)
	end
end
