--ピリ・レイスの地図
--Piri Reis Map
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Search 1 monster with 0 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsPhase(PHASE_MAIN1) and not Duel.CheckPhaseActivity()
end
function s.thfilter(c)
	return c:IsMonster() and c:IsAttack(0) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		local tc=g:GetFirst()
		if tc:IsLocation(LOCATION_HAND) then
			Duel.SetLP(tp,math.ceil(Duel.GetLP(tp)/2))
			local c=e:GetHandler()
			--Check Normal Summon for matching name
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_SUMMON_SUCCESS)
			e1:SetLabel(tc:GetCode())
			e1:SetOperation(s.checkop)
			e1:SetReset(RESET_PHASE|PHASE_END,2)
			Duel.RegisterEffect(e1,tp)
			--Cannot activate effects of monsters with the same name
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetTargetRange(1,0)
			e2:SetValue(s.aclimit)
			e2:SetLabelObject(e1)
			e2:SetReset(RESET_PHASE|PHASE_END,2)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local sc=eg:GetFirst()
	if sc:IsSummonPlayer(1-tp) then return end
	if sc:IsCode(e:GetLabel()) then e:SetLabel(-1) end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabelObject():GetLabel())
end