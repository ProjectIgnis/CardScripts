--EMコール (Anime)
--Performapal Call (Anime)
--scripted by Larry126
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x9f}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
function s.filter(c,def)
	return c:IsSetCard(0x9f) and c:IsDefenseBelow(def) and c:IsAbleToHand()
end
function s.rescon(atk)
	return	function(sg,e,tp,mg)
				return sg:GetSum(Card.GetDefense)==atk
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=Duel.GetAttacker()
	local atk=at:GetAttack()
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,atk)
	if chk==0 then return at:IsOnField() and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(atk),0) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at and at:IsRelateToBattle() and at:IsOnField() and Duel.NegateAttack() and at:IsStatus(STATUS_ATTACK_CANCELED) then
		local atk=at:GetAttack()
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil,atk)
		local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon(atk),1,tp,HINTMSG_ATOHAND)
		if #sg>0 then
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
			sg:ForEach(function(tc)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(EVENT_SUMMON_SUCCESS)
				e1:SetOperation(s.sumsuc)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EVENT_SPSUMMON_SUCCESS)
				tc:RegisterEffect(e2)
			end)
		end
	end
end
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_EXTRA))
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
