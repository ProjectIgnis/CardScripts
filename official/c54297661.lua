--ディメンション・リフレクター
--Dimension Reflector
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card in Attack Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rg=Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #rg>=2 and aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),0) end
	local g=aux.SelectUnselectGroup(rg,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,tp)
	return c:IsFaceup() and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT,c:GetAttack(),c:GetAttack(),4,RACE_SPELLCASTER,ATTRIBUTE_DARK)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.spfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,s.spfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if not (c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	local atk=tc:GetAttack()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id,0,TYPE_MONSTER|TYPE_EFFECT,atk,atk,4,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT|TYPE_TRAP)
	if Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP_ATTACK) then
		c:AddMonsterAttributeComplete()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE)
		e2:SetValue(atk)
		c:RegisterEffect(e2)
		--Inflict damage to your opponent equal to this card's ATK
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(id,0))
		e3:SetCategory(CATEGORY_DAMAGE)
		e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
		e3:SetCode(EVENT_SPSUMMON_SUCCESS)
		e3:SetTarget(s.damtg)
		e3:SetOperation(s.damop)
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e3,true)
	end
	Duel.SpecialSummonComplete()
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetAttack()
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,e:GetHandler():GetAttack(),REASON_EFFECT)
end