--トリガー・ヴルム 
--Triggering Wurm
local s,id=GetID()
function s.initial_effect(c)
	--If this card is sent to the GY as Link Material for the Link Summon of a DARK monster: You can Special Summon this card from your GY in Attack Position, to your zone that Link Monster points to, but it cannot be used as Link Material
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--If this card is destroyed or banished by an effect activated by a Link Monster: Draw 1 card
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_DRAW)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetCode(EVENT_DESTROYED)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCondition(s.drcon)
	e2a:SetTarget(s.drtg)
	e2a:SetOperation(s.drop)
	c:RegisterEffect(e2a)
	local e2b=e2a:Clone()
	e2b:SetCode(EVENT_REMOVE)
	e2b:SetCondition(aux.AND(s.drcon,function(e) return not e:GetHandler():IsReason(REASON_REDIRECT) end))
	c:RegisterEffect(e2b)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r&REASON_LINK==REASON_LINK and c:GetReasonCard():IsAttribute(ATTRIBUTE_DARK)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local link_monster=c:GetReasonCard()
	if chk==0 then
		local zones=link_monster:GetLinkedZone(tp)&ZONES_MMZ
		return zones>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,tp,zones)
	end
	e:SetLabelObject(link_monster)
	link_monster:CreateEffectRelation(e)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local link_monster=e:GetLabelObject()
	local zones=link_monster:GetLinkedZone(tp)&ZONES_MMZ
	if c:IsRelateToEffect(e) and link_monster:IsRelateToEffect(e) and zones>0
		and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP_ATTACK,zones) then
		--It cannot be used as Link Material
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3312)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
	Duel.SpecialSummonComplete()
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re:IsActivated() and re:IsMonsterEffect() and re:GetHandler():IsLinkMonster()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end