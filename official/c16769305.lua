--魔界造車－ＧＴ１９
--Turbo-Tainted Hot Rod GT19
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Register when it's flipped face-up
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_FLIP)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(s.flipop)
	c:RegisterEffect(e0)
	--Change its own level when Flipped summoned
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_LVCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvltg)
	e1:SetOperation(s.lvlop)
	c:RegisterEffect(e1)
	--Synchro Summon using only itself and a target
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return Duel.IsMainPhase() and e:GetHandler():GetFlagEffect(id)>0 end)
	e2:SetTarget(s.syncsumtg)
	e2:SetOperation(s.syncsumop)
	c:RegisterEffect(e2)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1)
end
function s.lvltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp,1,9,c:GetLevel())
	Duel.SetTargetParam(lv)
	Duel.SetOperationInfo(0,CATEGORY_LVCHANGE,c,1,tp,lv)
end
function s.lvlop(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and lv~=c:GetLevel() then
		local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESETS_STANDARD_DISABLE_PHASE_END)
		c:RegisterEffect(e1)
	end
end
function s.filter(c,this,tp)
	if not (c:IsFaceup() and c:HasLevel() and c:IsCanBeSynchroMaterial()) then return false end
	if c:IsControler(tp) then
		local mg=Group.FromCards(this,c)
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	--Temporarily register EFFECT_SYNCHRO_MATERIAL otherwise IsSynchroSummonable will fail with opponent's monsters 
	local e1=Effect.CreateEffect(this)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
	c:RegisterEffect(e1,true)
	local mg=Group.FromCards(this,c)
	local res=Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	e1:Reset()
	return res
end
function s.syncsumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc,c,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,c,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.syncsumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsImmuneToEffect(e) then return end
	if not (c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e)) then return end
	--Register EFFECT_SYNCHRO_MATERIAL, temporarily, only if it's an opponent's monster
	local e1=Effect.CreateEffect(c) --don't declare e1 localy inside the if, so it outlives that scope (to be used in e2)
	if tc:IsControler(1-tp) then
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_MATERIAL)
		tc:RegisterEffect(e1,true)
	end
	local mg=Group.FromCards(c,tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,1,nil,nil,mg)
	local sc=g:GetFirst()
	if sc then
		--Reset EFFECT_SYNCHRO_MATERIAL at the suitable time
		if tc:IsControler(1-tp) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_SPSUMMON_SUCCESS)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD-RESET_TOFIELD)
			e2:SetOperation(s.regop)
			e2:SetLabelObject(e1)
			sc:RegisterEffect(e2,true)
			local e3=e2:Clone()
			e3:SetCode(EVENT_SPSUMMON_NEGATED)
			sc:RegisterEffect(e3,true)
		end
		--Perform the Syncro Summon
		Duel.SynchroSummon(tp,sc,nil,mg)
	else
		e1:Reset()
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Reset()
	e:Reset()
end