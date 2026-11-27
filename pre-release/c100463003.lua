--幻想の守護神官マハード
--Illusion Palladium Oracle Mahad
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--If you have a banished LIGHT or DARK monster, you can Special Summon this card (from your hand). You can only Special Summon "Illusion Palladium Oracle Mahad" once per turn this way
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	--This card's original ATK is doubled while a DARK monster is on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SET_BASE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_DARK),0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end)
	e2:SetValue(function(e,c)
		return c:GetBaseAttack()*2
	end)
	c:RegisterEffect(e2)
	--If this card destroys a monster by battle and you have "Dark Magician" in your field or GY: Inflict damage to your opponent equal to the destroyed monster's original ATK
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_DARK_MAGICIAN),tp,LOCATION_ONFIELD|LOCATION_GRAVE,0,1,nil)
	end)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_DARK_MAGICIAN}
function s.spcon(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,ATTRIBUTE_LIGHT|ATTRIBUTE_DARK),tp,LOCATION_REMOVED,0,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local atk=e:GetHandler():GetBattleTarget():GetBaseAttack()
	if atk<0 then atk=0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(atk)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end