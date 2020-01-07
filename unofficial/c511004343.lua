--Spirit Battle
local s,id=GetID()
function s.initial_effect(c)
	--active
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,e,tp,tid)
	return (c:GetReason()&0x21)==0x21 and c:GetTurnID()==tid and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk)
	local tid=Duel.GetTurnCount()
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp,tid) and Duel.IsExistingTarget(s.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp,tid) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg1=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,tid)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg2=Duel.SelectTarget(1-tp,s.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,tid)
	local monster_1=tg1:GetFirst()
	local monster_2=tg2:GetFirst()
	local atk1=monster_1:GetAttack()
	local atk2=monster_2:GetAttack()
	Group.Merge(tg1,tg2)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tg,2,0,0)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp,chk)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg1=tg:Filter(Card.IsControler,nil,tp)
	local tg2=tg:Filter(Card.IsControler,nil,1-tp)
	Duel.SpecialSummon(tg1,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	Duel.SpecialSummon(tg2,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	local monster_1=tg1:GetFirst()
	local monster_2=tg2:GetFirst()
	local atk1=tg1:GetFirst():GetAttack()
	local atk2=tg2:GetFirst():GetAttack()
	local atk=tg:GetFirst()
	while atk do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e1:SetReset(RESET_CHAIN)
		e1:SetValue(1)
		atk:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetReset(RESET_CHAIN)
		e2:SetValue(1)
		atk:RegisterEffect(e2)
		atk=tg:GetNext()
	end
	Duel.CalculateDamage(monster_1,monster_2)
	if atk1>atk2 then
		Duel.RaiseSingleEvent(monster_1,EVENT_BATTLE_DAMAGE,e,REASON_EFFECT,0,1-tp,atk2)
	elseif atk1<atk2 then
		Duel.RaiseSingleEvent(monster_2,EVENT_BATTLE_DAMAGE,e,REASON_EFFECT,0,1-tp,atk1)
	else
		Duel.RaiseSingleEvent(monster_1,EVENT_BATTLE_DAMAGE,e,REASON_EFFECT,0,1-tp,atk2)
		Duel.RaiseSingleEvent(monster_2,EVENT_BATTLE_DAMAGE,e,REASON_EFFECT,0,1-tp,atk1)
	end
	if monster_1:IsStatus(STATUS_BATTLE_RESULT) then
		Duel.Damage(monster_1:GetControler(),atk1,REASON_EFFECT)
	end
	if monster_2:IsStatus(STATUS_BATTLE_RESULT) then
		Duel.Damage(monster_2:GetControler(),atk2,REASON_EFFECT)
	end
end