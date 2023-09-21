--エクストクス・ハイドラ
--Extox Hydra
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--2+ monsters you control Special Summoned from the Extra Deck
	Fusion.AddProcMixRep(c,true,true,s.ffilter,2,99)
	--Check materials used for Fusion Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	--Reduce ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e1:SetTarget(function(e,c) return c:IsType(e:GetHandler():GetFlagEffectLabel(id)) end)
	e1:SetValue(function(_,c) return -c:GetBaseAttack() end)
	c:RegisterEffect(e1)
	--Draw cards
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(function(_,tp,_,ep,ev) return ep==1-tp and ev>=1000 end)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSummonLocation(LOCATION_EXTRA)
end
function s.matcheck(e,c)
	local typ=c:GetMaterial():GetBitwiseOr(Card.GetType)&(TYPE_EXTRA|TYPE_PENDULUM)
	c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~RESET_TOFIELD,0,1,typ)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=ev//1000
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end