--Link Summon
function Auxiliary.AddLinkProcedure(c,f,min,max,specialchk,desc)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	if desc then
		e1:SetDescription(desc)
	else
		e1:SetDescription(1076)
	end
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_EXTRA)
	if max==nil then max=c:GetLink() end
	e1:SetCondition(Auxiliary.LinkCondition(f,min,max,specialchk))
	e1:SetTarget(Auxiliary.LinkTarget(f,min,max,specialchk))
	e1:SetOperation(Auxiliary.LinkOperation(f,min,max,specialchk))
	e1:SetValue(SUMMON_TYPE_LINK)
	c:RegisterEffect(e1)
end
function Auxiliary.LConditionFilter(c,f,lc,tp)
	return c:IsCanBeLinkMaterial(lc,tp) and (not f or f(c,lc,SUMMON_TYPE_LINK,tp))
end
function Auxiliary.GetLinkCount(c)
	if c:IsType(TYPE_LINK) and c:GetLink()>1 then
		return 1+0x10000*c:GetLink()
	else return 1 end
end
function Auxiliary.LCheckRecursive(c,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	if #sg>maxc then return false end
	filt=filt or {}
	local oldfilt={table.unpack(filt)}
	sg:AddCard(c)
	for _,f in ipairs(filt) do
		if not f[2](c,f[3],tp,sg,mg,lc,f[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			filt={table.unpack(oldfilt)}
			return false
		end
	end
	local res=Auxiliary.LCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
		or (#sg<maxc and mg:IsExists(Auxiliary.LCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,filt))
	sg:RemoveCard(c)
	filt={table.unpack(oldfilt)}
	return res
end
function Auxiliary.LCheckRecursive2(c,tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	if #sg>maxc then return false end
	local oldfilt={table.unpack(filt)}
	sg:AddCard(c)
	for _,f in ipairs(filt) do
		if not f[2](c,f[3],tp,sg,mg,lc,f[1],1) then
			sg:RemoveCard(c)
			return false
		end
	end
	if not og:IsContains(c) then
		res=aux.CheckValidExtra(c,tp,sg,mg,lc,emt,filt)
		if not res then
			sg:RemoveCard(c)
			filt={table.unpack(oldfilt)}
			return false
		end
	end
	if #(sg2-sg)==0 then
		if secondg and #secondg>0 then
			local res=secondg:IsExists(Auxiliary.LCheckRecursive,1,sg,tp,sg,mg,lc,minc,maxc,f,specialchk,og,emt,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		else
			local res=Auxiliary.LCheckGoal(tp,sg,lc,minc,f,specialchk,{table.unpack(filt)})
			sg:RemoveCard(c)
			return res
		end
	end
	local res=Auxiliary.LCheckRecursive2((sg2-sg):GetFirst(),tp,sg,sg2,secondg,mg,lc,minc,maxc,f,specialchk,og,emt,filt)
	sg:RemoveCard(c)
	return res
end
function Auxiliary.LCheckGoal(tp,sg,lc,minc,f,specialchk,filt)
	for _,f in ipairs(filt) do
		if not sg:IsExists(f[2],1,nil,f[3],tp,sg,Group.CreateGroup(),lc,f[1],1) then
			return false
		end
	end
	return #sg>=minc and sg:CheckWithSumEqual(Auxiliary.GetLinkCount,lc:GetLink(),#sg,#sg)
		and (not specialchk or specialchk(sg,lc,tp)) and Duel.GetLocationCountFromEx(tp,tp,sg,lc)>0
end
function Auxiliary.LinkCondition(f,minc,maxc,specialchk)
	return	function(e,c)
				if c==nil then return true end
				if c:IsType(TYPE_PENDULUM) and c:IsFaceup() then return false end
				local tp=c:GetControler()
				local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
				local mg=g:Filter(Auxiliary.LConditionFilter,nil,f,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
				if mustg:IsExists(aux.NOT(Auxiliary.LConditionFilter),1,nil,f,c,tp) then return false end
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
				local sg=mustg
				return (mg+tg):Includes(mustg) and (mg+tg):IsExists(Auxiliary.LCheckRecursive,1,nil,tp,sg,(mg+tg),c,minc,maxc,f,specialchk,mg,emt)
			end
end
function Auxiliary.LinkTarget(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk,c)
				local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
				local mg=g:Filter(Auxiliary.LConditionFilter,nil,f,c,tp)
				local mustg=Auxiliary.GetMustBeMaterialGroup(tp,g,tp,c,mg,REASON_LINK)
				local emt,tg=aux.GetExtraMaterials(tp,mustg+mg,c,SUMMON_TYPE_LINK)
				local sg=Group.CreateGroup()
				local cancel=false
				sg:Merge(mustg)
				while sg:GetCount()<maxc do
					local filters={}
					if #sg>0 then
						Auxiliary.LCheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,minc,maxc,f,specialchk,mg,emt,filters)
					end
					local cg=(mg+tg):Filter(Auxiliary.LCheckRecursive,sg,tp,sg,(mg+tg),c,minc,maxc,f,specialchk,mg,emt,filters)
					if cg:GetCount()==0 then break end
					if sg:GetCount()>=minc and sg:GetCount()<=maxc and Auxiliary.LCheckGoal(tp,sg,c,minc,f,specialchk,filters) then
						cancel=true
					else
						cancel=not og and Duel.GetCurrentChain()<=0 and sg:GetCount()==0
					end
					local tc=Group.SelectUnselect(cg,sg,tp,cancel,cancel,1,1)
					if not tc then break end
					if mustg:GetCount()==0 or not mustg:IsContains(tc) then
						if not sg:IsContains(tc) then
							sg:AddCard(tc)
						else
							sg:RemoveCard(tc)
						end
					end
				end
				if sg:GetCount()>0 then
					local filters={}
					Auxiliary.LCheckRecursive2(sg:GetFirst(),tp,Group.CreateGroup(),sg,mg+tg,mg+tg,c,minc,maxc,f,specialchk,mg,emt,filters)
					sg:KeepAlive()
					local reteff=Effect.GlobalEffect()
					reteff:SetTarget(function()return sg,filters end)
					e:SetLabelObject(reteff)
					return true
				else return false end
			end
end
function Auxiliary.LinkOperation(f,minc,maxc,specialchk)
	return	function(e,tp,eg,ep,ev,re,r,rp,c,smat,mg)
				local g,filt=e:GetLabelObject():GetTarget()()
				for _,ex in ipairs(filt) do
					if ex[3]:GetValue() then
						ex[3]:GetValue()(1,SUMMON_TYPE_LINK,ex[3],ex[1]&g,c,tp)
					end
				end
				c:SetMaterial(g)
				Duel.SendtoGrave(g,REASON_MATERIAL+REASON_LINK)
				g:DeleteGroup()
			end
end
