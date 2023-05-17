--ブースター・ワイバーン
--Booster Wyvern
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Inflict 300 Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_BLUETOOTH_B_DRAGON,CARD_REDBOOT_B_DRAGON}
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsStatus(STATUS_SUMMON_TURN+STATUS_SPSUMMON_TURN)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_BLUETOOTH_B_DRAGON,CARD_REDBOOT_B_DRAGON),tp,LOCATION_ONFIELD,0,1,nil)
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(600)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,val=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,val,REASON_EFFECT)
end
