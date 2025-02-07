--冥界龍 ドラゴネクロ
--Dragonecro Nethersoul Dragon
local s,id=GetID()
local TOKEN_DARK_SOUL=id+1
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 2 Zombie monsters
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_ZOMBIE),2)
	c:AddMustFirstBeFusionSummoned()
	--You can only control 1 "Dragonecro Nethersoul Dragon"
	c:SetUniqueOnField(1,0,id)
	--Monsters cannot be destroyed by battle with this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c==e:GetHandler():GetBattleTarget() end)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Change the ATK of a monster this card battles to 0 and Special Summon 1 "Dark Soul Token"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={id,TOKEN_DARK_SOUL}
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	Duel.SetTargetCard(bc)
	if bc:GetOriginalLevel()>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetFirstTarget()
	if bc:IsRelateToEffect(e) and bc:IsFaceup() then
		local c=e:GetHandler()
		local atk=bc:GetBaseAttack()
		--Change that monster's ATK to 0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local lv=bc:GetOriginalLevel()
		if lv>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_DARK_SOUL,0,TYPES_TOKEN,atk,0,lv,RACE_ZOMBIE,ATTRIBUTE_DARK) then
			local token=Duel.CreateToken(tp,TOKEN_DARK_SOUL)
			token:Level(lv)
			if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
				--Set the Token's original ATK to the original ATK of the monster that this card battled
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_SET_BASE_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT|RESETS_STANDARD)
				token:RegisterEffect(e1)
			end
			Duel.SpecialSummonComplete()
		end
	end
end