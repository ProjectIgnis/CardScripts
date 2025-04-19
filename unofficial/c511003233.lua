--冥界龍 ドラゴネクロ (Manga)
--Dragonecro Nethersoul Dragon (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--Must be Special Summoned properly
	c:EnableReviveLimit()
	--Fusion Materials (Hellfire Beauty + Hellfire Wyvern)
	Fusion.AddProcMix(c,true,true,61103515,99370594)
	--Special Summon "Dark Soul Token" with the same name, Level and ATK as battle target
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetTarget(s.attg)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
	--Monsters that battle this card cannot be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.indestg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={61103515,99370594}
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsFaceup() then
		local atk=bc:GetAttack()
		--Change ATK to 0
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		local code=bc:GetCode()
		local lv=bc:GetLevel()
		if lv>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsPlayerCanSpecialSummonMonster(tp,8198621,0,TYPES_TOKEN,-2,0,0,RACE_ZOMBIE,ATTRIBUTE_DARK) then
			local token=Duel.CreateToken(tp,8198621)
			Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
			--Change Token stats to reflect that of battled monster
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			token:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_CHANGE_LEVEL)
			e2:SetValue(lv)
			token:RegisterEffect(e2)
			local e3=e1:Clone()
			e3:SetCode(EFFECT_CHANGE_CODE)
			e3:SetValue(code)
			token:RegisterEffect(e3)
			--Monsters that battle this Token cannot be destroyed by battle
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_FIELD)
			e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e4:SetRange(LOCATION_MZONE)
			e4:SetTargetRange(0,LOCATION_MZONE)
			e4:SetTarget(s.indestg)
			e4:SetValue(1)
			token:RegisterEffect(e4)
			Duel.SpecialSummonComplete()
		end
	end
end
function s.indestg(e,c)
	return c==e:GetHandler():GetBattleTarget()
end