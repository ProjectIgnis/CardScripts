--天界王 シナト (Deck Master)
--Shinato, King of a Higher Plane (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme1:SetCode(EVENT_DAMAGE)
	dme1:SetCondition(s.reccon)
	dme1:SetOperation(s.recop)
	local dme2=Effect.CreateEffect(c)
	dme2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	dme2:SetCode(EFFECT_DESTROY_REPLACE)
	dme2:SetTarget(s.reptg)
	dme2:SetValue(s.repval)
	dme2:SetOperation(s.repop)
	DeckMaster.RegisterAbilities(c,dme1,dme2)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(s.damcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsMonster()
		and (bc:GetBattlePosition()&POS_DEFENSE)~=0
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=Duel.GetLP(1-tp)/2
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetLP(1-tp)/2
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.IsDeckMaster(tp,id)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Recover(tp,ev,REASON_EFFECT)
end
function s.repfilter(c,oc)
	return c==oc and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetOwner()
	if chk==0 then return Duel.GetDeckMaster(tp)==c and eg:IsExists(s.repfilter,1,nil,c) end
	if Duel.SelectEffectYesNo(tp,c,96) then
		return true
	else return false end
end
function s.repval(e,c)
	return c==e:GetOwner()
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	local c=e:GetOwner()
	c:MoveToDeckMasterZone(tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e1)
end