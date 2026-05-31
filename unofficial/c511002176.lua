--ギーブル (Manga)
--Guivre (Manga)
local s,id=GetID()
local TOKEN_WYVERN=18905770
function s.initial_effect(c)
	--When this card destroys an opponent's monster by battle: Special Summon 1 "Wyvern Token" to your field.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74440055,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={TOKEN_WYVERN}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,TOKEN_WYVERN,0,TYPES_TOKEN,400,400,1,RACE_DRAGON,ATTRIBUTE_LIGHT) then
		local token=Duel.CreateToken(tp,TOKEN_WYVERN)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end
