--ピース＆ロックンロール
--Peace & Rock n' Roll
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 monster and avoid damage for the rest of the turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_PRIMA_GUITARNA,160002025}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(CARD_PRIMA_GUITARNA,160002025)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp) and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #dg>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg,true)
		if Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.GetLP(tp)<=2000 then
			--avoid battle damage
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(1,0)
			e1:SetValue(1)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
			--No effect damage this turn
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CHANGE_DAMAGE)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e2:SetTargetRange(1,0)
			e2:SetValue(s.damval)
			e2:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e2,tp)
			local e3=e2:Clone()
			e3:SetCode(EFFECT_NO_EFFECT_DAMAGE)
			e3:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e3,tp)
		end
	end
end
function s.damval(e,re,val,r,rp,rc)
	if (r&REASON_EFFECT)~=0 and rp~=e:GetOwnerPlayer() then return 0
	else return val end
end