--死霊の残像
--Spirit Illusion
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a Level 5 or higher Fiend or Zombie monster
	aux.AddEquipProcedure(c,nil,s.eqfilter)
	--Make the opponent's monster lose ATK equal to the equipped monster's
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--Activate 1 of these effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.listed_names={id+1} --"Doppelganger Token"
function s.eqfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_FIEND|RACE_ZOMBIE)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local at,bt=Duel.GetBattleMonster(tp)
	local ec=e:GetHandler():GetEquipTarget()
	return at and bt and ec and at==ec and ec:GetAttack()>0 and bt:IsControler(1-tp)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at,bt=Duel.GetBattleMonster(tp)
	if chk==0 then return at:IsRelateToBattle() and bt:IsRelateToBattle() end
	Duel.SetTargetCard(bt)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,bt,1,tp,-e:GetHandler():GetEquipTarget():GetAttack())
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	local bc=Duel.GetFirstTarget()
	if ec and bc:IsRelateToEffect(e) and bc:IsFaceup() and bc:IsControler(1-tp) then
		local atk=ec:GetAttack()
		if atk<=0 then return end
		--Make that opponent's monster lose ATK equal to the equipped monster's
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		bc:RegisterEffect(e1)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	local b1=Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,0)
	local b2=ec and Duel.GetLocationCount(tp,LOCATION_MZONE)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,ec:GetAttack(),0,5,ec:GetRace(),ec:GetAttribute())
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Fusion Summon 1 Fusion Monster from your Extra Deck, using monsters from your hand or field as material
		Fusion.SummonEffOP()(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		--Special Summon 1 "Doppelganger Token" with the same Type, Attribute, and ATK as the equipped monster
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		local ec=e:GetHandler():GetEquipTarget()
		if not (ft>0 and Duel.IsPlayerCanSpecialSummonMonster(tp,id+1,0,TYPES_TOKEN,ec:GetAttack(),0,5,ec:GetRace(),ec:GetAttribute())) then return end
		local token=Duel.CreateToken(tp,id+1)
		--Set the Token's printed Type and Attribute
		token:Race(ec:GetRace())
		token:Attribute(ec:GetAttribute())
		if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
			--Set the Token's ATK to the equipped monster's
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(ec:GetAttack())
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			token:RegisterEffect(e1)
		end
		Duel.SpecialSummonComplete()
	end
end