--ミュステリオンの竜冠
--Mysterion the Dragon Crown
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Materials: 1 Spellcaster monster + 1 Dragon monster
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunctionEx(Card.IsRace,RACE_DRAGON))
	--Cannot be used as Fusion Material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--This card loses 100 ATK for each of your banished cards
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(function(e,cc) return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,0)*-100 end)
	c:RegisterEffect(e1)
	--Banish 1 Special Summoned monster, also banish all monsters from the field with its same original Type
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2a:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2a:SetCode(EVENT_CUSTOM+id)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,id)
	e2a:SetCondition(function() return not Duel.IsPhase(PHASE_DAMAGE) end)
	e2a:SetTarget(s.rmtg)
	e2a:SetOperation(s.rmop)
	c:RegisterEffect(e2a)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e2a:SetLabelObject(g)
	--Register summons
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetLabelObject(e2a)
	e2b:SetOperation(s.regop)
	c:RegisterEffect(e2b)
end
function s.tgfilter(c,rc,e)
	return c:IsLocation(LOCATION_MZONE) and (rc==c or (c:IsFaceup() and rc:IsOriginalRace(c:GetOriginalRace())))
		and c:IsAbleToRemove() and (not e or c:IsCanBeEffectTarget(e))
end
function s.tgfilter2(c,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:IsAbleToRemove() and (not e or c:IsCanBeEffectTarget(e))
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local rc=re:GetHandler()
	local g=e:GetLabelObject():Filter(s.tgfilter2,nil,e)
	if chkc then return g:IsContains(chkc) and s.tgfilter(chkc,nil) end
	if chk==0 then return #g>0 end
	local tc=nil
	if #g==1 then
		tc=g:GetFirst()
		Duel.SetTargetCard(tc)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		tc=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(tc)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tc,1,tp,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsOriginalRace,tc:GetOriginalRace()),tp,LOCATION_MZONE,LOCATION_MZONE,tc)+tc
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if eg:IsContains(c) then return end
	local rc=re:GetHandler()
	if not (re and re:IsActivated() and re:IsMonsterEffect() and rc) then return end
	local tg=eg:Filter(s.tgfilter,nil,rc)
	if #tg>0 then
		for tc in tg:Iter() do
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