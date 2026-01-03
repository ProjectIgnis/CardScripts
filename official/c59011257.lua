--フォーリンチーター
--Fallin' Cheatah
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--This face-up card in the Monster Zone cannot be Tributed, nor used as material for a Fusion, Synchro, Xyz, or Link Summon
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1a:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetValue(1)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e1b)
	local e1c=e1a:Clone()
	e1c:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e1c:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	c:RegisterEffect(e1c)
	--Give control of this card to that monster's controller, also that monster cannot be Tributed nor used as material for a Fusion, Synchro, Xyz or Link Summon while this monster is face-up on the field
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,0))
	e2a:SetCategory(CATEGORY_CONTROL)
	e2a:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2a:SetProperty(EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_CHECK_SIMULTANEOUS)
	e2a:SetCode(EVENT_CUSTOM+id)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetTarget(s.ctrltg)
	e2a:SetOperation(s.ctrlop)
	e2a:SetLabelObject(Group.CreateGroup())
	c:RegisterEffect(e2a)
	--Keep track of monsters Special Summoned to the opponent's field
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetLabelObject(e2a)
	e2b:SetOperation(s.regop)
	c:RegisterEffect(e2b)
end
function s.tgfilter(c,e,opp)
	return c:IsControler(opp) and c:IsLocation(LOCATION_MZONE) and (not e or c:IsCanBeEffectTarget(e))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local tg=eg:Filter(s.tgfilter,nil,nil,1-tp)
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
function s.ctrlfilter(c,tp)
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
end
function s.ctrltg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=e:GetLabelObject():Filter(s.tgfilter,nil,e,1-tp):Match(s.ctrlfilter,nil,tp)
	if chkc then return g:IsContains(chkc) and s.tgfilter(chkc,e,1-tp) end
	local c=e:GetHandler()
	if chk==0 then return true end
	if #g>0 then
		local tc=nil
		if #g>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			tc=g:Select(tp,1,1,nil):GetFirst()
		else
			tc=g:GetFirst()
		end
		Duel.SetTargetCard(tc)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,c,1,tp,0)
	end
end
function s.ctrlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.GetControl(c,tc:GetControler()) and c:IsFaceup() then
		c:SetCardTarget(tc)
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id+1,RESET_EVENT|(RESETS_STANDARD&~RESET_TURN_SET),EFFECT_FLAG_CLIENT_HINT,1,fid,aux.Stringid(id,1))
		--That monster cannot be Tributed nor used as material for a Fusion, Synchro, Xyz or Link Summon while this monster is face-up on the field
		local e1a=Effect.CreateEffect(c)
		e1a:SetType(EFFECT_TYPE_FIELD)
		e1a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1a:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1a:SetRange(LOCATION_MZONE)
		e1a:SetTarget(function(e,c) return c:GetFlagEffectLabel(id+1)==fid end)
		e1a:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e1a:SetValue(1)
		e1a:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1a)
		local e1b=e1a:Clone()
		e1b:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		c:RegisterEffect(e1b)
		local e1c=e1a:Clone()
		e1c:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e1c:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		c:RegisterEffect(e1c)
	end
end