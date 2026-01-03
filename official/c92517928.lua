--ギャラクシーアイズ・アンチマター・ドラゴン
--Galaxy-Eyes Antimatter Dragon
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 2 Level 9 monsters OR 1 Xyz Monster you control with 3 or more materials (transfer its materials)
	Xyz.AddProcedure(c,nil,9,2,function(c) return c:IsXyzMonster() and c:GetOverlayCount()>=3 and c:IsFaceup() end,aux.Stringid(id,0),2,s.altprocop)
	--Any battle damage this card with material inflicts to your opponent is halved
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetCondition(function(e) return e:GetHandler():GetOverlayCount()>0 end)
	e1:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e1)
	--Make this card gain the ability this turn to make up to 2 attacks on monsters during each Battle Phase, then if the detached material was a monster, you can send 1 monster with its same Type from your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function() return Duel.IsAbleToEnterBP() end)
	e2:SetCost(Cost.DetachFromSelf(1,1,function(e,og) local oc=og:GetFirst() e:SetLabel(oc:IsMonster() and oc:GetRace() or 0) end))
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.altprocop(e,tp,chk)
	if chk==0 then return not Duel.HasFlagEffect(tp,id) end
	return Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,EFFECT_FLAG_OATH,1)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsHasEffect(EFFECT_EXTRA_ATTACK_MONSTER) end
	local detached_type=e:GetLabel()
	e:SetLabel(0)
	Duel.SetTargetParam(detached_type)
	if detached_type>0 then
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
function s.tgfilter(c,detached_type)
	return c:IsRace(detached_type) and c:IsAbleToGrave()
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK_MONSTER) then
		--This card can make up to 2 attacks on monsters this turn
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3202)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		c:RegisterEffect(e1)
		local detached_type=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		if detached_type>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil,detached_type)
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil,detached_type)
			if #g>0 then
				Duel.BreakEffect()
				Duel.SendtoGrave(g,REASON_EFFECT)
			end
		end
	end
end