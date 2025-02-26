--サイバー・ラーバァ (Manga)
--Cyber Larva (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--When this card is destroyed, its controller takes no damage this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetCondition(s.nobattledmgcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetOperation(s.nodamop)
	c:RegisterEffect(e2)
	--Special Summon 1 card with the same name as this card from your Deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.nobattledmgcon(e)
	local c=e:GetHandler()
	if c:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE) or c:IsHasEffect(EFFECT_INDESTRUCTABLE) then return false end
	local bc=c:GetBattleTarget()
	if not bc then return false end
	if c==Duel.GetAttacker() then
		return bc:IsAttackPos() and bc:IsAttackAbove(1) and bc:IsAttackAbove(c:GetAttack())
	else
		local battle_stat=0
		if bc:IsAttackPos() then
			battle_stat=bc:GetAttack()
		else
			local def_attack_eff=bc:IsHasEffect(EFFECT_DEFENSE_ATTACK)
			battle_stat=def_attack_eff:GetValue()==1 and bc:GetDefense() or bc:GetAttack()
		end
		return battle_stat>0 and ((c:IsAttackPos() and c:IsAttackBelow(battle_stat))
			or (c:IsDefensePos() and c:GetDefense()<battle_stat))
	end
end
function s.nodamop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local prev_ctrl=c:GetPreviousControler()
	--Its controller takes no damage this turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetTargetRange(1,0)
	e1:SetValue(0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,prev_ctrl)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	Duel.RegisterEffect(e2,prev_ctrl)
end
function s.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,e:GetHandler():GetCode()) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,c:GetCode())
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end