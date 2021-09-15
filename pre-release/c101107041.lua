-- 相剣大邪－七星龍淵
-- Qixing Long Yuan, the Swordsoul Catastrophe
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	c:EnableReviveLimit()
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_WYRM),1,99)
	--Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.drcon)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
	--Banish monster
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2:SetLabelObject(g)
	--Register summons
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2a:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetLabelObject(e2)
	e2a:SetOperation(s.regop)
	c:RegisterEffect(e2a)
	--Banish Spell/Trap
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,{id,2})
	e3:SetCondition(s.rmcon2)
	e3:SetTarget(s.rmtg2)
	e3:SetOperation(s.rmop2)
	c:RegisterEffect(e3)
end
function s.cfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
		and c:IsRace(RACE_WYRM) and c:IsSummonPlayer(tp)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,e:GetHandler(),e,tp)
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
--banish monster
function s.filter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsAbleToRemove()
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=e:GetLabelObject():Filter(s.filter,nil,tp)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=e:GetLabelObject()
	if #g==0 then return end 
	local bg=g:FilterSelect(tp,s.filter,1,1,nil,tp)
	if #bg>0 and Duel.Remove(bg,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=eg:Filter(s.filter,nil,tp)
	if #tg>0 then
		for tc in aux.Next(tg) do
			tc:RegisterFlagEffect(id,RESET_CHAIN,0,1)
		end
		local g=e:GetLabelObject():GetLabelObject()
		if Duel.GetCurrentChain()==0 then g:Clear() end
		g:Merge(tg)
		g:Remove(function(c) return c:GetFlagEffect(id)==0 end,nil)
		e:GetLabelObject():SetLabelObject(g)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+id,e,0,tp,tp,0)
	end
end
--banish spell/trap
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) 
end
function s.rmtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rg,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1200)
end
function s.rmop2(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsRelateToEffect(re) then return end
	if Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)>0 then
		Duel.Damage(1-tp,1200,REASON_EFFECT)
	end
end