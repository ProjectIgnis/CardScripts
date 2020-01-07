--エクシーズ熱戦！！
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_XYZ) and c:IsPreviousControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if s.cfilter(tc,tp) then
		e:SetLabel(tc:GetRank())
		return true
	end
	tc=eg:GetNext()
	if tc and s.cfilter(tc,tp) then
		e:SetLabel(tc:GetRank())
		return true
	end
	return false
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	Duel.PayLPCost(tp,1000)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsRankBelow,tp,LOCATION_EXTRA,0,1,nil,e:GetLabel()) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local tc1=Duel.SelectMatchingCard(tp,Card.IsRankBelow,tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel()):GetFirst()
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
	local tc2=Duel.SelectMatchingCard(1-tp,Card.IsRankBelow,1-tp,LOCATION_EXTRA,0,1,1,nil,e:GetLabel()):GetFirst()
	if tc1 and tc2 then
		Duel.ConfirmCards(1-tp,tc1)
		Duel.ConfirmCards(tp,tc2)
		local atk1=tc1:GetAttack()
		local atk2=tc2:GetAttack()
		if atk1>atk2 then
			Duel.Damage(1-tp,atk1-atk2,REASON_EFFECT)
		elseif atk1<atk2 then
			Duel.Damage(tp,atk2-atk1,REASON_EFFECT)
		end
	elseif tc1 then
		Duel.ConfirmCards(1-tp,tc1)
		Duel.Damage(1-tp,tc1:GetAttack(),REASON_EFFECT)
	elseif tc2 then
		Duel.ConfirmCards(tp,tc2)
		Duel.Damage(tp,tc2:GetAttack(),REASON_EFFECT)
	end
end
