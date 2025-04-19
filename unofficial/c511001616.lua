--ラプターズ・アルティメット・メイス (Anime)
--Raptor's Ultimate Mace (Anime)
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,SET_RAIDRAPTOR))
	--increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	c:RegisterEffect(e1)
	--make battle damage 0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_series={0x95,0xba}
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local eq=c:GetEquipTarget()
	if not eq then return false end
	local bc=eq:GetBattleTarget()
	if not bc or eq:GetEffectCount(EFFECT_INDESTRUCTABLE_BATTLE)>0 then return false end
	if eq:IsAttackPos() and bc:IsAttackPos() and eq:GetAttack()<=bc:GetAttack() then return true end
	if eq:IsDefensePos() and eq:GetDefense()<bc:GetAttack() then return true end
	return false
end
function s.afilter(c)
	return c:IsSetCard(SET_RANK_UP_MAGIC) and c:IsSpell() and c:IsAbleToHand()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local eq=e:GetHandler():GetEquipTarget()
	local g=Duel.GetMatchingGroup(s.afilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(984114,0)) then
		Duel.ChangeBattleDamage(eq:GetControler(),0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end