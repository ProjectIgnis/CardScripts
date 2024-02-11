--共命の翼ガルーラ
--Garura, Wings of Resonant Life
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMixN(c,true,true,s.ffilter,2)
	--Double battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
	--Draw 1 card when sent to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
function s.ffilter(c,fc,sumtype,sump,sub,matg,sg)
	return not sg or sg:FilterCount(aux.TRUE,c)==0 or (sg:IsExists(Card.IsAttribute,1,c,c:GetAttribute(),fc,sumtype,sump)
		and sg:IsExists(Card.IsRace,1,c,c:GetRace(),fc,sumtype,sump)
		and not sg:IsExists(s.fusfilter,1,c,c:GetCode(fc,sumtype,sump),fc,sumtype,sump))
end
function s.fusfilter(c,code,fc,sumtype,sump)
	return c:IsSummonCode(fc,sumtype,sump,code) and not c:IsHasEffect(511002961)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end